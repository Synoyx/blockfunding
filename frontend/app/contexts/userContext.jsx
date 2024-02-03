import { createContext, useContext, useState, useEffect } from "react";
import { VotingFunctions, callReadMethod } from "@/app/js/wagmiWrapper.js";
import { useAccount } from "wagmi";

const UserContext = createContext();

export const UserRoles = {
  visitor: "Visitor",
  voter: "Voter",
  owner: "Owner",
  ownerAndVoter: "Owner and Voter",
};

export const UserContextProvider = ({ children }) => {
  const [hasVoted, setHasVoted] = useState(false);
  const [votedId, setVotedId] = useState("");
  const [userRole, setUserRole] = useState(UserRoles.visitor);
  const [loadingUserRole, setLoadingUserRole] = useState(false);
  const { address, isConnected } = useAccount();

  useEffect(() => {
    if (isConnected === true) {
      setLoadingUserRole(true);
      let isOwnerValue = false,
        isVoterValue = false;

      async function loadUserRole() {
        const ownerAddress = await callReadMethod(
          VotingFunctions.owner,
          address
        );
        isOwnerValue = ownerAddress === address ? true : false;

        try {
          const voter = await callReadMethod(
            VotingFunctions.getVoter,
            address,
            [address]
          );
          isVoterValue = voter.isRegistered;
          setHasVoted(voter.hasVoted);
          setVotedId(voter.votedProposalId);
        } catch (e) {}

        if (isOwnerValue && isVoterValue) setUserRole(UserRoles.ownerAndVoter);
        else if (isOwnerValue) setUserRole(UserRoles.owner);
        else if (isVoterValue) setUserRole(UserRoles.voter);
        else setUserRole(UserRoles.visitor);

        setLoadingUserRole(false);
      }

      loadUserRole();
    }
  }, [address, isConnected]);

  function isVoter() {
    return userRole === UserRoles.ownerAndVoter || userRole === UserRoles.voter;
  }

  function isOwner() {
    return userRole === UserRoles.ownerAndVoter || userRole === UserRoles.owner;
  }

  return (
    <UserContext.Provider
      value={{
        isOwner,
        isVoter,
        userRole,
        hasVoted,
        loadingUserRole,
        setHasVoted,
        votedId,
        setVotedId,
      }}
    >
      {children}
    </UserContext.Provider>
  );
};

export const useUserContext = () => useContext(UserContext);
